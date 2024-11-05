package com.opdehipt.email_alias.presentation

import android.app.RemoteInput
import android.content.Context
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Chip
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material3.MaterialTheme
import androidx.wear.compose.material3.Text
import androidx.wear.input.RemoteInputIntentHelper
import androidx.wear.tooling.preview.devices.WearDevices
import com.opdehipt.email_alias.API
import com.opdehipt.email_alias.PreferencesStore
import com.opdehipt.email_alias.R
import com.opdehipt.email_alias.database.Email
import com.opdehipt.email_alias.database.getDB
import com.opdehipt.email_alias.presentation.theme.AndroidTheme
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.launch

private const val LETTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._"

private fun randomString(length: Int) = (0..<length).map { LETTERS.random() }.joinToString("")

private suspend fun addEmail(context: Context, description: String) {
    val preferences = PreferencesStore(context)
    val db = getDB(context)

    val emails = db.emailDao.getAll()
    val goto = preferences.email.firstOrNull()!!
    val domain = goto.split("@").last()

    var address: String
    do {
        val alias = randomString(20)
        address = "$alias@$domain"
    }
    while (emails.firstOrNull { it.address == address } != null)

    val id = if (API.testMode(context)) {
        val id = preferences.nextID.firstOrNull()!!
        preferences.setNextID(id + 1)
        id
    }
    else {
        API.addEmail(context, address, description, listOf(goto))
    }
    if (id != null) {
        val email = Email(id, address, description, listOf(goto), true)
        getDB(context).emailDao.insertEmail(email)
    }
}

@Composable
fun AddEmailView() {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()
    var description by remember { mutableStateOf("") }

    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            TextInput(stringResource(R.string.enter_description), description, {
                description = it
            })
            Spacer(Modifier.height(20.dp))
            Chip(
                onClick = {
                    coroutineScope.launch {
                        addEmail(context, description)
                    }
                },
                label = { Text(stringResource(R.string.add_email)) },
                colors = ChipDefaults.primaryChipColors()
            )
        }
    }
}

@Composable
private fun TextInput(
    placeholder: String,
    value: String?,
    onChange: (value: String) -> Unit,
) {
    val launcher =
        rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) {
            it.data?.let { data ->
                val results = RemoteInput.getResultsFromIntent(data)
                val newValue = results.getCharSequence(placeholder)
                onChange(newValue.toString())
            }
        }
    Column {
        Chip(
            label = { Text(if (value == null || value.isEmpty()) placeholder else value) },
            onClick = {
                val intent = RemoteInputIntentHelper.createActionRemoteInputIntent();
                val remoteInputs = listOf(
                    RemoteInput.Builder(placeholder)
                        .setLabel(placeholder)
                        .build()
                )

                RemoteInputIntentHelper.putRemoteInputsExtra(intent, remoteInputs)

                launcher.launch(intent)
            }
        )
    }
}

@Preview(device = WearDevices.SMALL_ROUND, showSystemUi = true)
@Composable
private fun DefaultPreview() {
    AndroidTheme {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(5.dp),
            contentAlignment = Alignment.Center
        ) {
            AddEmailView()
        }
    }
}