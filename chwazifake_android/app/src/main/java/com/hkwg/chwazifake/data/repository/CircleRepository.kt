package com.hkwg.chwazifake.data.repository

import com.hkwg.chwazifake.data.model.Circle

interface CircleRepository {
    fun addCircle(circle: Circle)
    fun getCircles(): List<Circle>
} 