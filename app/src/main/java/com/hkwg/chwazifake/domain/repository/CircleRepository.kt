package com.hkwg.chwazifake.domain.repository

import com.hkwg.chwazifake.domain.model.CircleState

interface CircleRepository {
    fun addCircle(circle: CircleState)
    fun removeCircle(circle: CircleState)
    fun updateCircle(circle: CircleState)
    fun getCircles(): List<CircleState>
} 