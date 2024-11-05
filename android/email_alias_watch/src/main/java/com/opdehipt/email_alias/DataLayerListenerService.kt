package com.opdehipt.email_alias

import android.app.LocaleManager
import android.os.Build
import android.os.LocaleList
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.os.LocaleListCompat
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMap
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.WearableListenerService
import com.opdehipt.email_alias.database.getDB
import com.opdehipt.email_alias.database.testEmails
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

class DataLayerListenerService : WearableListenerService() {

    override fun onDataChanged(dataEvents: DataEventBuffer) {
        dataEvents.forEach {
            val map = DataMapItem.fromDataItem(it.dataItem).dataMap

            CoroutineScope(Dispatchers.IO + Job()).launch {
                when (map.getString("type")) {
                    "register" -> register(map)
                    "logout" -> logout()
                    "clearCache" -> clearCache()
                    "settings" -> updateSettings(map)
                }
            }
        }
    }

    private suspend fun register(data: DataMap) {
        val email = data.getString("email")!!
        val domain = data.getString("domain")!!
        val apiKey = data.getString("apiKey")!!
        PreferencesStore(this).register(email, domain, apiKey)

        if (domain == API.TEST_DOMAIN) {
            getDB(this).emailDao.insertEmails(testEmails)
        }
    }

    private suspend fun logout() {
        PreferencesStore(this).logout()
        getDB(this).emailDao.deleteAll()
    }

    private suspend fun clearCache() {
        getDB(this).emailDao.deleteAll()
    }

    private fun updateSettings(data: DataMap) {
        val locale = data.getInt("locale")
        val localeTag = when (locale) {
            1 -> "en-US"
            2 -> "de-DE"
            else -> null
        }
        if (localeTag != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                getSystemService(LocaleManager::class.java).applicationLocales =
                    LocaleList.forLanguageTags(localeTag)
            } else {
                AppCompatDelegate.setApplicationLocales(
                    LocaleListCompat.forLanguageTags(localeTag)
                )
            }
        }
    }
}