package com.opdehipt.email_alias

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class PreferencesStore(private val context: Context) {
    private companion object {
        val Context.dataStore by preferencesDataStore("preferences")
        val REGISTERED_KEY = booleanPreferencesKey("registered")
        val DOMAIN_KEY = stringPreferencesKey("domain")
        val EMAIL_KEY = stringPreferencesKey("email")
        val API_KEY = stringPreferencesKey("apiKey")
        val NEXT_ID = intPreferencesKey("nextID")

        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
    }

    private fun generateEncryptionKey(): SecretKey {
        val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
        val keyGenParameter = KeyGenParameterSpec.Builder(
            "preferences_encryption_key",
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setKeySize(256)
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setRandomizedEncryptionRequired(false)
            .build()

        keyGenerator.init(keyGenParameter)
        return keyGenerator.generateKey()
    }

    private fun hasEncryptionKey() = keyStore.containsAlias("preferences_encryption_key")

    private fun getEncryptionKey() =
        if (hasEncryptionKey()) {
            keyStore.getKey("preferences_encryption_key", null) as SecretKey
        }
        else {
            generateEncryptionKey()
        }

    private fun generateRandomIV(): String {
        val random = SecureRandom()
        val generated = random.generateSeed(12)
        return Base64.encodeToString(generated, Base64.DEFAULT)
    }

    private fun getCipherFromIV(iv: String, cipherMode: Int): Cipher {
        val parameterSpec = GCMParameterSpec(128, Base64.decode(iv, Base64.DEFAULT))
        return Cipher.getInstance("AES/GCM/NoPadding").apply { init(cipherMode, getEncryptionKey(), parameterSpec) }
    }

    private fun encrypt(value: String): String {
        val aesIV =  generateRandomIV()
        val cipher = getCipherFromIV(aesIV, Cipher.ENCRYPT_MODE)
        val encodedBytes = cipher.doFinal(value.toByteArray(Charsets.UTF_8))

        return "$aesIV:${Base64.encodeToString(encodedBytes, Base64.DEFAULT)}"
    }

    fun decrypt(value: String?) =
        if (value == null) {
            null
        }
        else {
            val (publicIV, encrypted) = value.split(":")
            val decodedValue = Base64.decode(encrypted.toByteArray(Charsets.UTF_8), Base64.DEFAULT)
            val cipher = getCipherFromIV(publicIV, Cipher.DECRYPT_MODE)
            val decryptedVal = cipher.doFinal(decodedValue)

            String(decryptedVal)
        }

    val registered: Flow<Boolean> = context.dataStore.data
        .map { preferences ->
            preferences[REGISTERED_KEY] == true
        }

    val domain: Flow<String?> = context.dataStore.data
        .map { preferences ->
            preferences[DOMAIN_KEY]
        }

    val email: Flow<String?> = context.dataStore.data
        .map { preferences ->
            preferences[EMAIL_KEY]
        }

    val apiKey: Flow<String?> = context.dataStore.data
        .map { preferences ->
            decrypt(preferences[API_KEY])
        }

    val nextID: Flow<Int?> = context.dataStore.data
        .map { preferences ->
            preferences[NEXT_ID]
        }

    suspend fun setNextID(id: Int) {
        context.dataStore.edit { preferences ->
            preferences[NEXT_ID] = id
        }
    }

    suspend fun register(email: String, domain: String, apiKey: String) {
        context.dataStore.edit { preferences ->
            preferences[REGISTERED_KEY] = true
            preferences[EMAIL_KEY] = email
            preferences[DOMAIN_KEY] = domain
            preferences[API_KEY] = encrypt(apiKey)
        }
    }

    suspend fun logout() {
        context.dataStore.edit { preferences ->
            preferences.remove(REGISTERED_KEY)
            preferences.remove(EMAIL_KEY)
            preferences.remove(DOMAIN_KEY)
            preferences.remove(API_KEY)
        }
    }
}