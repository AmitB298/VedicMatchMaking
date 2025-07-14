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
fun RegisterScreen(navController: NavController, onRegister: (String, String, String) -> Unit) {
var email by remember { mutableStateOf("") }
var password by remember { mutableStateOf("") }
var displayName by remember { mutableStateOf("") }
Column(modifier = Modifier
.fillMaxSize()
.padding(16.dp)) {
Text("Register", style = MaterialTheme.typography.headlineMedium)
Spacer(Modifier.height(16.dp))
OutlinedTextField(
value = displayName,
onValueChange = { displayName = it },
label = { Text("Display Name") },
modifier = Modifier.fillMaxWidth()
)
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
onClick = { onRegister(email, password, displayName) },
modifier = Modifier.fillMaxWidth()
) {
Text("Register")
}
Spacer(Modifier.height(8.dp))
TextButton(
onClick = { navController.navigate("login") },
modifier = Modifier.fillMaxWidth()
) {
Text("Already have an account? Login")
}
}
}
