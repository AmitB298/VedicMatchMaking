package com.yourapp.ui.auth

import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController









@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoginScreen(navController: NavController) {
var emailOrPhone by remember { mutableStateOf("") }
var password by remember { mutableStateOf("") }
Column(modifier = Modifier.padding(16.dp)) {
Text("Login", style = MaterialTheme.typography.h4)
Spacer(modifier = Modifier.height(16.dp))
OutlinedTextField(
value = emailOrPhone,
onValueChange = { emailOrPhone = it },
label = { Text("Email or Phone") },
modifier = Modifier.fillMaxWidth()
)
Spacer(modifier = Modifier.height(8.dp))
OutlinedTextField(
value = password,
onValueChange = { password = it },
label = { Text("Password") },
modifier = Modifier.fillMaxWidth()
)
Spacer(modifier = Modifier.height(16.dp))
Button(onClick = { /* TODO: Handle login */ }, modifier = Modifier.fillMaxWidth()) {
Text("Login")
}
Spacer(modifier = Modifier.height(16.dp))
SocialLoginButtons(onGoogleClick = {}, onFacebookClick = {})
}
}
