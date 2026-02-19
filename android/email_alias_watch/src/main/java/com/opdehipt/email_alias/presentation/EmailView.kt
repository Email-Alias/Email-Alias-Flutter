package com.opdehipt.email_alias.presentation

import android.content.Context
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.material3.pulltorefresh.rememberPullToRefreshState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
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
import androidx.navigation.NavHostController
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.material.Chip
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material.ExperimentalWearMaterialApi
import androidx.wear.compose.material.SwipeToRevealChip
import androidx.wear.compose.material.SwipeToRevealDefaults
import androidx.wear.compose.material.SwipeToRevealPrimaryAction
import androidx.wear.compose.material.rememberRevealState
import androidx.wear.compose.material3.Icon
import androidx.wear.compose.material3.MaterialTheme
import androidx.wear.compose.material3.Text
import androidx.wear.compose.navigation.rememberSwipeDismissableNavController
import androidx.wear.tooling.preview.devices.WearDevices
import com.opdehipt.email_alias.API
import com.opdehipt.email_alias.PreferencesStore
import com.opdehipt.email_alias.R
import com.opdehipt.email_alias.database.Email
import com.opdehipt.email_alias.database.EmailDatabase
import com.opdehipt.email_alias.database.getDB
import com.opdehipt.email_alias.database.testEmails
import com.opdehipt.email_alias.presentation.theme.AndroidTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.launch
import kotlin.time.Duration.Companion.seconds

@Composable
fun EmailView(navController: NavHostController, db: EmailDatabase) {
    val context = LocalContext.current

    suspend fun loadEmails() {
        if (!API.testMode(context)) {
            val gotoEmail = PreferencesStore(context).email.firstOrNull()
            var emails = API.getEmails(context)
            emails = emails.filter { it.goto.contains(gotoEmail) }

            val cachedEmails = db.emailDao.getAll()
            for (email in emails) {
                val firstCached = cachedEmails.firstOrNull { it.id == email.id }
                if (firstCached != null) {
                    if (firstCached != email) {
                        db.emailDao.updateEmail(email)
                    }
                }
                else {
                    db.emailDao.insertEmail(email)
                }
            }

            val deleteEmails = cachedEmails.filter { email -> emails.filter { email.id == it.id }.isEmpty() }
            for (email in deleteEmails) {
                db.emailDao.deleteEmail(email)
            }
        }
    }

    LaunchedEffect(Unit) {
        loadEmails()
    }

    val emails by db.emailDao.getAllFlow().collectAsState(emptyList())
    EmailList(navController, emails) {
        loadEmails()
    }
}

private suspend fun deleteEmail(context: Context, email: Email) {
    API.deleteEmails(context, listOf(email))
    getDB(context).emailDao.deleteEmail(email)
}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalWearMaterialApi::class)
@Composable
private fun EmailList(navController: NavHostController, emails: List<Email>, loadEmails: suspend () -> Unit) {
    val context = LocalContext.current
    var isRefreshing by remember { mutableStateOf(false) }
    val pullToRefreshState = rememberPullToRefreshState()
    val coroutineScope = rememberCoroutineScope()
    PullToRefreshBox(
        state = pullToRefreshState,
        isRefreshing = isRefreshing,
        onRefresh = {
            coroutineScope.launch {
                isRefreshing = true
                loadEmails()
                isRefreshing = false
            }
        }
    ) {
        ScalingLazyColumn {
            item {
                Chip(
                    modifier = Modifier.fillMaxWidth(),
                    onClick = {
                        navController.navigate(
                            Routes.Add.route
                        )
                    },
                    label = { Text(stringResource(R.string.add_email)) },
                    colors = ChipDefaults.primaryChipColors()
                )
            }
            items(emails.size) { i ->
                val revealState = rememberRevealState()
                SwipeToRevealChip(
                    revealState = revealState,
                    primaryAction = {
                        SwipeToRevealPrimaryAction(
                            revealState = revealState,
                            icon = { Icon(SwipeToRevealDefaults.Delete, contentDescription = stringResource(R.string.delete_email)) },
                            label = { Text(stringResource(R.string.delete_email)) },
                            onClick = {
                                coroutineScope.launch {
                                    deleteEmail(context, emails[i])
                                }
                            }
                        )
                    },
                    onFullSwipe = {
                        coroutineScope.launch {
                            deleteEmail(context, emails[i])
                        }
                    }
                ) {
                    Chip(
                        modifier = Modifier.fillMaxWidth(),
                        onClick = {
                            navController.navigate(
                                Routes.EmailDetail.route.replace(
                                    "{id}",
                                    emails[i].id.toString()
                                )
                            )
                        },
                        label = { Text(emails[i].privateComment) },
                        colors = ChipDefaults.secondaryChipColors()
                    )
                }
            }
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
            EmailList(rememberSwipeDismissableNavController(), testEmails) {
                delay(5.seconds)
            }
        }
    }
}