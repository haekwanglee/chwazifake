package com.hkwg.chwazifake.data.repository

import com.hkwg.chwazifake.domain.model.CircleState
import com.hkwg.chwazifake.domain.repository.CircleRepository
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CircleRepositoryImpl @Inject constructor() : CircleRepository {
    private val circles = mutableListOf<CircleState>()

    override fun addCircle(circle: CircleState) {
        circles.add(circle)
    }

    override fun removeCircle(circle: CircleState) {
        circles.removeIf { it.position == circle.position }
    }

    override fun updateCircle(circle: CircleState) {
        val index = circles.indexOfFirst { it.position == circle.position }
        if (index != -1) {
            circles[index] = circle
        }
    }

    override fun getCircles(): List<CircleState> = circles.toList()
} 