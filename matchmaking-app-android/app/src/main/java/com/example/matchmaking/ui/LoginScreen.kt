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
fun LoginScreen(
navController: NavController,
onGoogleClick: () -> Unit = {},
onFacebookClick: () -> Unit = {}
) {
Scaffold(
topBar = {
TopAppBar(title = { Text("Login") })
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
Text("Welcome! Please log in.")
Spacer(modifier = Modifier.height(16.dp))
SocialLoginButtons(onGoogleClick, onFacebookClick)
Spacer(modifier = Modifier.height(8.dp))
Button(onClick = { navController.navigate("register") }) {
Text("Don't have an account? Register")
}
}
}
}
