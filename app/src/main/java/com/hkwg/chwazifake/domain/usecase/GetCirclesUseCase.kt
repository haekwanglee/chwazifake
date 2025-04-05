package com.hkwg.chwazifake.domain.usecase

import com.hkwg.chwazifake.data.repository.CircleRepository
import com.hkwg.chwazifake.domain.model.CircleDomain
import javax.inject.Inject

class GetCirclesUseCase @Inject constructor(
    private val repository: CircleRepository
) {
    operator fun invoke(): List<CircleDomain> {
        return repository.getCircles().map { it.toDomain() }
    }

    private fun com.hkwg.chwazifake.data.model.Circle.toDomain() = CircleDomain(
        position = position,
        radius = radius
    )
} 