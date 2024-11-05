package com.opdehipt.email_alias.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material3.MaterialTheme
import androidx.wear.compose.navigation.SwipeDismissableNavHost
import androidx.wear.compose.navigation.composable
import androidx.wear.compose.navigation.rememberSwipeDismissableNavController
import androidx.wear.tooling.preview.devices.WearDevices
import com.opdehipt.email_alias.database.EmailDatabase
import com.opdehipt.email_alias.database.getDB
import com.opdehipt.email_alias.presentation.theme.AndroidTheme

sealed class Routes {
    abstract val route: String

    object Index: Routes() {
        override val route = "/"
    }
    object Add: Routes() {
        override val route = "/add"
    }
    object EmailDetail: Routes() {
        override val route = "/email/{id}"
    }
}

@Composable
fun NavigationView(db: EmailDatabase) {
    val navController = rememberSwipeDismissableNavController()
    SwipeDismissableNavHost(navController, startDestination = Routes.Index.route) {
        composable(Routes.Index.route) {
            LicenseScaffold {
                EmailView(navController, db)
            }
        }
        composable(Routes.Add.route) {
            AddEmailView()
        }
        composable(Routes.EmailDetail.route) {
            EmailDetailView(db, it.arguments?.getString("id")?.toIntOrNull())
        }
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
            NavigationView(getDB())
        }
    }
}