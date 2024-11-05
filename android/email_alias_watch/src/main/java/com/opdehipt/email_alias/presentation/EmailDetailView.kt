package com.opdehipt.email_alias.presentation

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.wear.compose.foundation.pager.VerticalPager
import androidx.wear.compose.foundation.pager.rememberPagerState
import androidx.wear.compose.material.Scaffold
import androidx.wear.compose.material3.MaterialTheme
import androidx.wear.compose.material3.Text
import androidx.wear.compose.material3.VerticalPageIndicator
import androidx.wear.tooling.preview.devices.WearDevices
import com.opdehipt.email_alias.R
import com.opdehipt.email_alias.database.Email
import com.opdehipt.email_alias.database.EmailDatabase
import com.opdehipt.email_alias.database.testEmails
import com.opdehipt.email_alias.presentation.theme.AndroidTheme

@Composable
fun EmailDetailView(db: EmailDatabase, id: Int?) {
    var email by remember { mutableStateOf<Email?>(null) }

    LaunchedEffect(id) {
        if (id != null) {
            email = db.emailDao.get(id)
        }
    }
    if (email != null) {
        InnerEmailDetailView(email!!)
    }
    else {
        Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize().padding(10.dp)) {
            Text(stringResource(R.string.email_not_found), textAlign = TextAlign.Center)
        }
    }
}

@Composable
private fun InnerEmailDetailView(email: Email) {
    val pagerState = rememberPagerState { 2 }
    Scaffold(
        positionIndicator = {
            VerticalPageIndicator(
                pagerState
            )
        }
    ) {
        VerticalPager(pagerState) { page ->
            if (page == 0) {
                EmailQrView(email)
            } else {
                EmailInfoView(email)
            }
        }
    }
}

@Composable
private fun EmailQrView(email: Email) {
    Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
        Image(
            painter = rememberQrBitmapPainter("mailto:${email.address}", size = 130.dp),
            contentDescription = stringResource(R.string.qr_code_for, email.address),
            contentScale = ContentScale.FillBounds,
            alignment = Alignment.Center
        )
    }
}

@Composable
private fun EmailInfoView(email: Email) {
    Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize().padding(10.dp)) {
        Text(stringResource(R.string.email_address, email.address), textAlign = TextAlign.Center)
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
            InnerEmailDetailView(testEmails.first())
        }
    }
}