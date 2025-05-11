package com.hkwg.chwazifake.di.module

import com.hkwg.chwazifake.data.repository.CircleRepositoryImpl
import com.hkwg.chwazifake.domain.repository.CircleRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    @Binds
    @Singleton
    abstract fun bindCircleRepository(
        repository: CircleRepositoryImpl
    ): CircleRepository
} 