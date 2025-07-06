package com.matchmaking.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.matchmaking.app.core.network.AuthRequest
import com.matchmaking.app.core.network.RetrofitInstance
import kotlinx.coroutines.launch

@Composable
fun Screen() {
    val scope = rememberCoroutineScope()

    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var displayName by remember { mutableStateOf("") }
    var result by remember { mutableStateOf("") }

    Column(modifier = Modifier.padding(16.dp)) {
        Text(text = "🧭 Diagnostic  Screen", style = MaterialTheme.typography.h5)
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = email, onValueChange = { email = it }, label = { Text("Email") })
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = password, onValueChange = { password = it }, label = { Text("Password") })
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = displayName, onValueChange = { displayName = it }, label = { Text("Display Name (Register only)") })
        Spacer(modifier = Modifier.height(16.dp))
        Row {
            Button(onClick = {
                scope.launch {
                    try {
                        val res = RetrofitInstance.api.register(AuthRequest(email, password, displayName))
                        result = "✅ Register Success: \"
                    } catch (e: Exception) {
                        result = "❌ Register Failed: \"
                    }
                }
            }) {
                Text("Register")
            }
            Spacer(modifier = Modifier.width(8.dp))
            Button(onClick = {
                scope.launch {
                    try {
                        val res = RetrofitInstance.api.login(AuthRequest(email, password))
                        result = "✅ Login Success: \"
                    } catch (e: Exception) {
                        result = "❌ Login Failed: \"
                    }
                }
            }) {
                Text("Login")
            }
        }
        Spacer(modifier = Modifier.height(16.dp))
        Text(result)
    }
}
