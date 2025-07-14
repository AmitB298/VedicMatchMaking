package com.yourapp.ui.auth

import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp









@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SocialLoginButtons(
onGoogleClick: () -> Unit,
onFacebookClick: () -> Unit
) {
Column {
Button(onClick = onGoogleClick, modifier = Modifier.fillMaxWidth()) {
Text("Continue with Google")
}
Spacer(modifier = Modifier.height(8.dp))
Button(onClick = onFacebookClick, modifier = Modifier.fillMaxWidth()) {
Text("Continue with Facebook")
}
}
}
