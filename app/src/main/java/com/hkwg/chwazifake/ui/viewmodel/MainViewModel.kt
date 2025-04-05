package com.hkwg.chwazifake.ui.viewmodel

import androidx.compose.runtime.State
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.lifecycle.ViewModel
import com.hkwg.chwazifake.domain.model.CircleState
import com.hkwg.chwazifake.domain.usecase.HandleCircleUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlin.random.Random

@HiltViewModel
class MainViewModel @Inject constructor(
    private val handleCircleUseCase: HandleCircleUseCase
) : ViewModel() {

    private val _circles = mutableStateOf<List<CircleState>>(emptyList())
    val circles: State<List<CircleState>> = _circles

    private val colors = listOf(
        Color(0xFF2196F3), // Blue
        Color(0xFFE91E63), // Red
        Color(0xFF4CAF50), // Green
        Color(0xFFFFEB3B), // Yellow
        Color(0xFF9C27B0), // Purple
        Color(0xFFFF9800), // Orange
        Color(0xFF00BCD4), // Cyan
        Color(0xFFFF4081), // Pink
        Color(0xFF009688), // Teal
        Color(0xFFCDDC39)  // Lime
    )

    fun onTouch(position: Offset) {
        val circle = CircleState(
            position = position,
            color = colors[Random.nextInt(colors.size)],
            innerRadius = 0f,
            outerRadius = 0f,
            isGrowing = true
        )
        handleCircleUseCase.addCircle(circle)
        updateCircles()
    }

    fun onRelease(position: Offset) {
        val circleToRemove = _circles.value.find { it.position == position }
        circleToRemove?.let {
            handleCircleUseCase.removeCircle(it)
            updateCircles()
        }
    }

    fun animateCircles() {
        _circles.value.forEach { circle ->
            val updatedCircle = handleCircleUseCase.animateCircle(circle)
            handleCircleUseCase.updateCircle(updatedCircle)
        }
        updateCircles()
    }

    private fun updateCircles() {
        _circles.value = handleCircleUseCase.getCircles()
    }
} 
