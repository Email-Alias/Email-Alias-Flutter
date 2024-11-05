package com.opdehipt.email_alias.database

import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.serialization.KSerializer
import kotlinx.serialization.Serializable
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder

@Entity
@Serializable
data class Email(
    @PrimaryKey
    val id: Int,
    val address: String,
    val privateComment: String,
    @Serializable(with = ListAsStringSerializer::class)
    var goto: List<String>,
    @Serializable(with = BooleanAsIntSerializer::class)
    var active: Boolean,
)

object ListAsStringSerializer : KSerializer<List<String>> {
    override val descriptor = PrimitiveSerialDescriptor("List<String>", PrimitiveKind.STRING)
    override fun serialize(encoder: Encoder, value: List<String>) = encoder.encodeString(value.joinToString(","))
    override fun deserialize(decoder: Decoder): List<String> = decoder.decodeString().split(",")
}

object BooleanAsIntSerializer : KSerializer<Boolean> {
    override val descriptor = PrimitiveSerialDescriptor("Boolean", PrimitiveKind.INT)
    override fun serialize(encoder: Encoder, value: Boolean) = encoder.encodeInt(if (value) 1 else 0)
    override fun deserialize(decoder: Decoder): Boolean = decoder.decodeInt() == 1
}
