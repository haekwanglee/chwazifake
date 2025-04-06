package com.hkwg.chwazifake.ui.component

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.input.pointer.PointerInputScope
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.input.pointer.PointerEventPass
import androidx.compose.ui.input.pointer.PointerId
import androidx.compose.ui.input.pointer.changedToDownIgnoreConsumed
import androidx.compose.ui.input.pointer.changedToUpIgnoreConsumed
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
            .background(Color.Black)
            .pointerInput(Unit) {
                detectMultiTouch(
                    onTouch = onTouch,
                    onRelease = onRelease
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

private suspend fun PointerInputScope.detectMultiTouch(
    onTouch: (Offset) -> Unit,
    onRelease: (Offset) -> Unit
) {
    awaitEachGesture {
        val pointers = mutableSetOf<PointerId>()

        while (true) {
            val event = awaitPointerEvent(PointerEventPass.Main)

            event.changes.forEach { change ->
                when {
                    change.changedToDownIgnoreConsumed() && !pointers.contains(change.id) -> {
                        if (pointers.size < 10) {  // 최대 10개의 터치 포인트 제한
                            pointers.add(change.id)
                            onTouch(change.position)
                        }
                    }
                    change.changedToUpIgnoreConsumed() && pointers.contains(change.id) -> {
                        pointers.remove(change.id)
                        onRelease(change.position)
                    }
                }
                change.consume()
            }

            if (event.changes.all { it.changedToUpIgnoreConsumed() }) {
                break
            }
        }
    }
} 