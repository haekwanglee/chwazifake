package com.hkwg.chwazifake.data.model

import androidx.compose.ui.geometry.Offset

/**
 * Data 레이어의 Circle 모델
 * 초기 데이터 정의와 데이터 소스와의 매핑을 담당
 */
data class Circle(
    val position: Offset,
    val radius: Float = 0f,
    val isGrowing: Boolean = true,
    val color: CircleColor = CircleColor.BLUE
) {
    enum class CircleColor {
        BLUE,
        RED,
        GREEN
    }

    companion object {
        fun createInitial(position: Offset): Circle = Circle(
            position = position,
            radius = 0f,
            isGrowing = true,
            color = CircleColor.BLUE
        )
    }
} 