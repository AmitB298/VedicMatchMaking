package com.matchmaking.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
@Composable
fun registerScreen() {
    var email by remember { mutableStateOf(\"\") }
    var password by remember { mutableStateOf(\"\") }    var displayName by remember { mutableStateOf(\"\") }
    var photoURL by remember { mutableStateOf(\"\") }
    Column(modifier = Modifier.padding(16.dp)) {
        Text(text = \" Screen\", style = MaterialTheme.typography.h5)
        Spacer(modifier = Modifier.height(8.dp))        OutlinedTextField(value = displayName, onValueChange = { displayName = it }, label = { Text(\"Display Name\") })
        Spacer(modifier = Modifier.height(8.dp))        OutlinedTextField(value = email, onValueChange = { email = it }, label = { Text(\"Email\") })
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = password, onValueChange = { password = it }, label = { Text(\"Password\") }, visualTransformation = PasswordVisualTransformation())        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = photoURL, onValueChange = { photoURL = it }, label = { Text(\"Photo URL\") })        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = { /* TODO: Call ViewModel to submit */ }) {
            Text(text = \"\")
        }
    }
}
