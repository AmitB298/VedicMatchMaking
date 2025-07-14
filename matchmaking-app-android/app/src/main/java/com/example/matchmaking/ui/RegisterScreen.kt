package com.example.matchmaking.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController









@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegisterScreen(
navController: NavController,
onGoogleClick: () -> Unit = {},
onFacebookClick: () -> Unit = {}
) {
Scaffold(
topBar = {
TopAppBar(title = { Text("Register") })
}
) { padding ->
Column(
modifier = Modifier
.fillMaxSize()
.padding(padding)
.padding(16.dp),
verticalArrangement = Arrangement.Center,
horizontalAlignment = Alignment.CenterHorizontally
) {
Text("Create your account")
Spacer(modifier = Modifier.height(16.dp))
SocialLoginButtons(onGoogleClick, onFacebookClick)
Spacer(modifier = Modifier.height(8.dp))
Button(onClick = { navController.navigate("login") }) {
Text("Already have an account? Login")
}
}
}
}
