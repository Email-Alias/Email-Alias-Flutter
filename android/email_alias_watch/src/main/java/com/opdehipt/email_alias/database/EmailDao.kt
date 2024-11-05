package com.opdehipt.email_alias.database

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface EmailDao {
    @Query("SELECT * FROM email")
    suspend fun getAll(): List<Email>

    @Query("SELECT * FROM email")
    fun getAllFlow(): Flow<List<Email>>

    @Query("SELECT * FROM email WHERE id = :id")
    suspend fun get(id: Int): Email

    @Insert
    suspend fun insertEmail(email: Email)

    @Insert
    suspend fun insertEmails(emails: List<Email>)

    @Update
    suspend fun updateEmail(email: Email)

    @Delete
    suspend fun deleteEmail(email: Email)

    @Query("DELETE FROM Email")
    suspend fun deleteAll()
}