package com.example.matchmaking.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp









@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SocialLoginButtons(
onGoogleClick: () -> Unit,
onFacebookClick: () -> Unit
) {
Column(
modifier = Modifier.fillMaxWidth(),
verticalArrangement = Arrangement.spacedBy(8.dp)
) {
Button(
onClick = onGoogleClick,
modifier = Modifier.fillMaxWidth()
) {
Text("Continue with Google")
}
Button(
onClick = onFacebookClick,
modifier = Modifier.fillMaxWidth()
) {
Text("Continue with Facebook")
}
}
}
