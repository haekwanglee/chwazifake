package com.hkwg.chwazifake.domain.usecase

import com.hkwg.chwazifake.data.repository.CircleRepository
import com.hkwg.chwazifake.domain.model.CircleDomain
import javax.inject.Inject

class AddCircleUseCase @Inject constructor(
    private val repository: CircleRepository
) {
    operator fun invoke(circle: CircleDomain) {
        repository.addCircle(circle.toData())
    }

    private fun CircleDomain.toData() = com.hkwg.chwazifake.data.model.Circle(
        position = position,
        radius = radius
    )
} 