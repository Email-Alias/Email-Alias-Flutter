package com.opdehipt.email_alias.presentation


import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material3.MaterialTheme
import androidx.wear.tooling.preview.devices.WearDevices
import com.opdehipt.email_alias.PreferencesStore
import com.opdehipt.email_alias.database.EmailDatabase
import com.opdehipt.email_alias.database.getDB
import com.opdehipt.email_alias.presentation.theme.AndroidTheme

@Composable
fun ContentView(db: EmailDatabase) {
    val registered by PreferencesStore(LocalContext.current)
        .registered.collectAsState(false)
    if (registered) {
        NavigationView(db)
    } else {
        RegisterView()
    }
}

@Preview(device = WearDevices.SMALL_ROUND, showSystemUi = true)
@Composable
private fun DefaultPreview() {
    val db = getDB()
    AndroidTheme {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(5.dp),
            contentAlignment = Alignment.Center
        ) {
            ContentView(db)
        }
    }
}