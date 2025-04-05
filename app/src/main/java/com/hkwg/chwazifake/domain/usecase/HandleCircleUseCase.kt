package com.hkwg.chwazifake.domain.usecase

import androidx.compose.ui.geometry.Offset
import com.hkwg.chwazifake.domain.model.CircleState
import com.hkwg.chwazifake.domain.repository.CircleRepository
import javax.inject.Inject

class HandleCircleUseCase @Inject constructor(
    private val repository: CircleRepository
) {
    fun addCircle(circle: CircleState) {
        repository.addCircle(circle)
    }

    fun removeCircle(circle: CircleState) {
        repository.removeCircle(circle)
    }

    fun updateCircle(circle: CircleState) {
        repository.updateCircle(circle)
    }

    fun getCircles(): List<CircleState> = repository.getCircles()

    fun animateCircle(circle: CircleState): CircleState {
        var updatedCircle = circle.grow()

        if (updatedCircle.shouldStopGrowing()) {
            updatedCircle = updatedCircle.changeDirection()
        }

        return updatedCircle
    }
} 