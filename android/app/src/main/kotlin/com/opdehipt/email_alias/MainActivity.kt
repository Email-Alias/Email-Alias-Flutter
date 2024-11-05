package com.opdehipt.email_alias

import android.annotation.SuppressLint
import com.google.android.gms.wearable.CapabilityClient
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.DataMap
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

class MainActivity: FlutterActivity() {
    private companion object {
        const val FLUTTER_CHANNEL = "com.opdehipt.email_alias/watch"
        const val WATCH_CHANNEL = "/data-changed"
    }

    private lateinit var dataClient: DataClient
    private lateinit var capabilityClient: CapabilityClient

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FLUTTER_CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "updateApplicationContext" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val args = call.arguments as Map<*, *>
                            val map = DataMap()
                            for ((key, value) in args) {
                                when (value) {
                                    is String -> map.putString(key as String, value)
                                    is Byte -> map.putByte(key as String, value)
                                    is Int -> map.putInt(key as String, value)
                                    is Long -> map.putLong(key as String, value)
                                    is Float -> map.putFloat(key as String, value)
                                    is Double -> map.putDouble(key as String, value)
                                    is Boolean -> map.putBoolean(key as String, value)
                                }
                            }
                            map.putLong("timestamp", System.currentTimeMillis())
                            updateApplicationContext(map)
                            result.success(null)
                        }
                        catch (e: Exception) {
                            result.error(e.message ?: "", e.localizedMessage, e)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
        dataClient = Wearable.getDataClient(this)
        capabilityClient = Wearable.getCapabilityClient(this)
    }

    @SuppressLint("QueryPermissionsNeeded")
    private suspend fun updateApplicationContext(context: DataMap) {
        val apps = packageManager.getInstalledApplications(0)
        val wearableAppInstalled = apps.any {
            it.packageName == "com.google.android.wearable.app" ||
            it.packageName == "com.samsung.android.app.watchmanager"
        }
        val appInstalledOnWatch = capabilityClient.getCapability(
            "email_alias_watch",
            CapabilityClient.FILTER_ALL,
        ).await().nodes.isNotEmpty()
        if (wearableAppInstalled && appInstalledOnWatch) {
            val dataItem = PutDataMapRequest.create(WATCH_CHANNEL).apply {
                dataMap.putAll(context)
                dataMap.putLong("timestamp", System.currentTimeMillis())
            }.asPutDataRequest()
            dataClient.putDataItem(dataItem).await()
        }
    }
}
