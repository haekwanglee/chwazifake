package com.hkwg.chwazifake.ui.screen

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import com.hkwg.chwazifake.ui.component.TouchCircleCanvas
import com.hkwg.chwazifake.ui.viewmodel.MainViewModel

@Composable
fun MainScreen(
    modifier: Modifier = Modifier,
    viewModel: MainViewModel = hiltViewModel()
) {
    TouchCircleCanvas(
        circles = viewModel.circles.value,
        onTouch = viewModel::onTouch,
        onRelease = viewModel::onRelease,
        onAnimate = viewModel::animateCircles,
        modifier = modifier
    )
} 