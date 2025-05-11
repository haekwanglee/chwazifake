package com.hkwg.chwazifake.domain.model

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color

data class CircleState(
    val position: Offset,
    val color: Color,
    val innerRadius: Float = 0f,
    val outerRadius: Float = 0f,
    val isGrowing: Boolean = true
) {
    companion object {
        const val MIN_RADIUS = 50f
        const val MAX_RADIUS = 100f
        const val ANIMATION_STEP = 2f
    }

    fun grow(): CircleState {
        return if (isGrowing) {
            copy(
                innerRadius = innerRadius + ANIMATION_STEP,
                outerRadius = outerRadius + ANIMATION_STEP
            )
        } else {
            copy(
                innerRadius = innerRadius - ANIMATION_STEP,
                outerRadius = outerRadius - ANIMATION_STEP
            )
        }
    }

    fun shouldStopGrowing(): Boolean {
        return isGrowing && outerRadius >= MAX_RADIUS
    }

    fun changeDirection(): CircleState {
        return copy(isGrowing = !isGrowing)
    }
} 