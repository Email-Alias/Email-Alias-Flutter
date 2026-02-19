package com.opdehipt.email_alias.database

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverter
import androidx.room.TypeConverters

@Database(entities = [Email::class], version = 1)
@TypeConverters(Converters::class)
abstract class EmailDatabase: RoomDatabase() {
    abstract val emailDao: EmailDao
}

object Converters {
    @TypeConverter
    fun fromString(value: String) = value.split(',')

    @TypeConverter
    fun fromArrayList(list: List<String>) = list.joinToString(",") { it.trim() }
}

@Composable
fun getDB() = getDB(LocalContext.current)

fun getDB(context: Context): EmailDatabase {
    val db by lazy {
        Room.databaseBuilder(
            context = context,
            klass = EmailDatabase::class.java,
            name = "datamodel.db"
        ).build()
    }
    return db
}

val testEmails = listOf(
    Email(0, "vAcd8HJOj6h9Hfq9n8F0@example.com", "Apple", emptyList(), false),
    Email(1, "gQo5Nu.H7j774eh3mscM@example.com", "Google", emptyList(), false),
    Email(2, "FPOjzL0h86Qq9yTZ8Ix4@example.com", "Netflix", emptyList(), false),
    Email(3, "glELoo9GWGnpT0VIZujM@example.com", "GitHub", emptyList(), false),
    Email(4, "nI0Ok0Q8x9hNutIiFRAK@example.com", "Facebook", emptyList(), false),
    Email(5, "yugS_xb992eLm3jRlk3Z@example.com", "Microsoft", emptyList(), false),
    Email(6, "11iLJ6HK6jshFzqFOo6P@example.com", "Amazon", emptyList(), false)
)