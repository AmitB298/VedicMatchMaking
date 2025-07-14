package com.matchmaking.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController









@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoginScreen(navController: NavController, onLogin: (String, String) -> Unit) {
var email by remember { mutableStateOf("") }
var password by remember { mutableStateOf("") }
Column(modifier = Modifier
.fillMaxSize()
.padding(16.dp)) {
Text("Login", style = MaterialTheme.typography.headlineMedium)
Spacer(Modifier.height(16.dp))
OutlinedTextField(
value = email,
onValueChange = { email = it },
label = { Text("Email") },
modifier = Modifier.fillMaxWidth()
)
OutlinedTextField(
value = password,
onValueChange = { password = it },
label = { Text("Password") },
modifier = Modifier.fillMaxWidth()
)
Spacer(Modifier.height(16.dp))
Button(
onClick = { onLogin(email, password) },
modifier = Modifier.fillMaxWidth()
) {
Text("Login")
}
Spacer(Modifier.height(8.dp))
TextButton(
onClick = { navController.navigate("register") },
modifier = Modifier.fillMaxWidth()
) {
Text("Don't have an account? Register")
}
}
}
