package com.hkwg.chwazifake.di.module

import com.hkwg.chwazifake.domain.repository.CircleRepository
import com.hkwg.chwazifake.domain.usecase.HandleCircleUseCase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ViewModelComponent
import dagger.hilt.android.scopes.ViewModelScoped

@Module
@InstallIn(ViewModelComponent::class)
object UseCaseModule {
    @Provides
    @ViewModelScoped
    fun provideHandleCircleUseCase(
        repository: CircleRepository
    ): HandleCircleUseCase = HandleCircleUseCase(repository)
} 