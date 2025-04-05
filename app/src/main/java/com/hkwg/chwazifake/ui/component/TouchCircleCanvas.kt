package com.hkwg.chwazifake.ui.component

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.input.pointer.pointerInput
import com.hkwg.chwazifake.domain.model.CircleState
import kotlinx.coroutines.delay

@Composable
fun TouchCircleCanvas(
    circles: List<CircleState>,
    onTouch: (Offset) -> Unit,
    onRelease: (Offset) -> Unit,
    onAnimate: () -> Unit,
    modifier: Modifier = Modifier
) {
    LaunchedEffect(Unit) {
        while (true) {
            delay(16) // ~60fps
            onAnimate()
        }
    }

    Canvas(
        modifier = modifier
            .fillMaxSize()
            .pointerInput(Unit) {
                detectTapGestures(
                    onPress = { offset ->
                        onTouch(offset)
                        tryAwaitRelease()
                        onRelease(offset)
                    }
                )
            }
    ) {
        circles.forEach { circle ->
            drawCircle(circle)
        }
    }
}

private fun DrawScope.drawCircle(circle: CircleState) {
    drawCircle(
        color = circle.color,
        center = circle.position,
        radius = circle.outerRadius,
        alpha = 0.5f
    )
    drawCircle(
        color = circle.color,
        center = circle.position,
        radius = circle.innerRadius
    )
} 