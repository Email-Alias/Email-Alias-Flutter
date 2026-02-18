package com.opdehipt.email_alias

import android.content.Context
import com.opdehipt.email_alias.database.Email
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.engine.okhttp.OkHttp
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.HttpRequestBuilder
import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.client.request.url
import io.ktor.http.HttpHeaders
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonNamingStrategy

object API {
    const val TEST_DOMAIN = "test.mail.opdehipt.com"

    @OptIn(ExperimentalSerializationApi::class)
    private val client = HttpClient(OkHttp) {
        install(ContentNegotiation) {
            json(Json {
                namingStrategy = JsonNamingStrategy.SnakeCase
                ignoreUnknownKeys = true
            })
        }
    }

    private val Context.preferences
        get() = PreferencesStore(this)

    private suspend fun domain(context: Context) = context.preferences.domain.firstOrNull()

    private suspend fun apiURL(context: Context) = "https://${domain(context)}/api/v1/"

    private suspend fun baseReq(context: Context, url: String): HttpRequestBuilder {
        val apiKey = context.preferences.apiKey.firstOrNull()
        val builder = HttpRequestBuilder()
        builder.url(apiURL(context) + url)
        builder.header(HttpHeaders.Accept, "application/json")
        builder.header(HttpHeaders.ContentType, "application/json")
        builder.header("X-API-Key", apiKey)
        return builder
    }

    suspend fun testMode(context: Context) = domain(context) == TEST_DOMAIN

    suspend fun getEmails(context: Context): List<Email> {
        val goto = context.preferences.email.firstOrNull()
        val req = baseReq(context, "get/alias/all")
        val resp = client.get(req)
        return resp.body<List<Email>>().filter { it.goto.contains(goto) && it.privateComment.isNotEmpty() }
    }

    suspend fun addEmail(context: Context, address: String, privateComment: String, additionalGotos: List<String>): Int? {
        val goto = context.preferences.email.firstOrNull()
        val gotoString = (additionalGotos + listOf(goto)).joinToString(",")
        val email = EmailReq(true, false, true, address, gotoString, privateComment)
        val req = baseReq(context, "add/alias")
        req.setBody(email)
        val (success, result) = basicSend(req)
        return if (success) {
            result[0].msg[2].toIntOrNull()
        } else {
            null
        }
    }

    suspend fun deleteEmails(context: Context, emails: List<Email>): Boolean {
        val ids = emails.map { it.id }
        val req = baseReq(context, "delete/alias")
        req.setBody(ids)
        val (success, _) = basicSend(req)
        return success
    }

    private suspend fun basicSend(req: HttpRequestBuilder): Pair<Boolean, List<Result>> {
        val res = client.post(req)
        val jsonRes = res.body<List<Result>>()
        return jsonRes.all { it.type == "success" } to jsonRes
    }
}

@Serializable
private data class EmailReq(
    val active: Boolean,
    val sogoVisible: Boolean,
    val senderAllowed: Boolean,
    val address: String,
    val goto: String,
    val privateComment: String,
)

@Serializable
private data class Result(
    val type: String,
    val msg: List<String>,
)
