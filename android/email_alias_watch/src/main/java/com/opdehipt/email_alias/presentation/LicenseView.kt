package com.opdehipt.email_alias.presentation

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.wear.compose.foundation.pager.rememberPagerState
import androidx.wear.compose.material.Scaffold
import androidx.wear.compose.material3.HorizontalPageIndicator
import androidx.wear.compose.material3.MaterialTheme
import androidx.wear.compose.material3.Text
import androidx.wear.tooling.preview.devices.WearDevices
import com.opdehipt.email_alias.R
import com.opdehipt.email_alias.presentation.theme.AndroidTheme

@Composable
fun LicenseScaffold(body: @Composable () -> Unit) {
    val pagerState = rememberPagerState { 2 }
    Scaffold (
        positionIndicator = { HorizontalPageIndicator(pagerState) }
    ) {
        HorizontalPager(pagerState) { page ->
            if (page == 0) {
                body()
            } else {
                LicenseView()
            }
        }
    }
}

@Composable
private fun LicenseView() {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            stringResource(R.string.licenses),
            fontSize = MaterialTheme.typography.titleLarge.fontSize
        )
        Spacer(Modifier.height(10.dp))
        Image(
            rememberQrBitmapPainter(
                "https://github.com/Email-Alias/Email-Alias-Flutter/blob/main/android/app/build.gradle",
                100.dp
            ),
            stringResource(R.string.licenses),
            contentScale = ContentScale.FillBounds,
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
            LicenseView()
        }
    }
}