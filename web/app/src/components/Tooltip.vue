<template>
  <div
    id="tooltip"
    ref="tooltip"
    :class="[
      'absolute z-50 px-3 py-2 text-sm rounded-md shadow-lg border transition-all duration-200',
      'bg-popover text-popover-foreground border-border',
      hidden ? 'invisible opacity-0' : 'visible opacity-100'
    ]"
    :style="`top: ${top}px; left: ${left}px;`"
  >
    <div v-if="result" class="space-y-2">
      <!-- Status -->
      <div class="flex items-center gap-2">
        <span :class="[
          'inline-block w-2 h-2 rounded-full',
          result.success ? 'bg-green-500' : 'bg-red-500'
        ]"></span>
        <span class="text-xs font-semibold">
          {{ result.success ? '正常' : '异常' }}
        </span>
      </div>

      <!-- Timestamp -->
      <div>
        <div class="text-xs font-semibold text-muted-foreground">检测时间</div>
        <div class="font-mono text-xs">{{ prettifyTimestamp(result.timestamp) }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, nextTick, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { prettifyTimestamp } from '@/utils/time'

const route = useRoute()

const props = defineProps({
  event: {
    type: [Event, Object],
    default: null
  },
  result: {
    type: Object,
    default: null
  },
  isPersistent: {
    type: Boolean,
    default: false
  }
})

// State
const hidden = ref(true)
const top = ref(0)
const left = ref(0)
const tooltip = ref(null)
const targetElement = ref(null)

// Methods are imported from utils/time

// Update tooltip position based on target element's current position
const updatePosition = async () => {
  if (!targetElement.value || !tooltip.value || hidden.value) return

  await nextTick()

  const targetRect = targetElement.value.getBoundingClientRect()
  const tooltipRect = tooltip.value.getBoundingClientRect()

  // For absolute positioning, we need to add scroll offsets
  const scrollTop = window.pageYOffset || document.documentElement.scrollTop
  const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft

  // Default position: below the target (viewport coords + scroll offset)
  let newTop = targetRect.bottom + scrollTop + 8
  let newLeft = targetRect.left + scrollLeft

  // Check if tooltip would overflow the viewport bottom
  const spaceBelow = window.innerHeight - targetRect.bottom
  const spaceAbove = targetRect.top

  if (spaceBelow < tooltipRect.height + 20) {
    // Not enough space below, try above
    if (spaceAbove > tooltipRect.height + 20) {
      // Position above
      newTop = targetRect.top + scrollTop - tooltipRect.height - 8
    } else {
      // Not enough space above either, position at the best spot
      if (spaceAbove > spaceBelow) {
        // More space above
        newTop = scrollTop + 10
      } else {
        // More space below or equal, keep below but adjust
        newTop = scrollTop + window.innerHeight - tooltipRect.height - 10
      }
    }
  }

  // Adjust horizontal position if tooltip would overflow right edge
  const spaceRight = window.innerWidth - targetRect.left
  if (spaceRight < tooltipRect.width + 20) {
    // Align right edge of tooltip with right edge of target
    newLeft = targetRect.right + scrollLeft - tooltipRect.width
    // Make sure it doesn't go off the left edge
    if (newLeft < scrollLeft + 10) {
      newLeft = scrollLeft + 10
    }
  }

  top.value = Math.round(newTop)
  left.value = Math.round(newLeft)
}

const reposition = async () => {
  if (!props.event || !props.event.type) return

  await nextTick()

  if ((props.event.type === 'mouseenter' || props.event.type === 'click') && tooltip.value) {
    const target = props.event.target
    // Store the target element for scroll updates
    targetElement.value = target

    // First, make tooltip visible to get its dimensions
    hidden.value = false
    await nextTick()

    // Update position
    await updatePosition()
  } else if (props.event.type === 'mouseleave') {
    // Only hide on mouseleave if not in persistent mode
    if (!props.isPersistent) {
      hidden.value = true
      targetElement.value = null
    }
  }
}

// Handle resize events (still needed for viewport size changes)
const handleResize = () => {
  updatePosition()
}

// Lifecycle hooks
onMounted(() => {
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
})

// Watchers
watch(() => props.event, (newEvent) => {
  if (newEvent && newEvent.type) {
    if (newEvent.type === 'mouseenter' || newEvent.type === 'click') {
      hidden.value = false
      nextTick(() => reposition())
    } else if (newEvent.type === 'mouseleave') {
      // Only hide on mouseleave if not in persistent mode
      if (!props.isPersistent) {
        hidden.value = true
      }
    }
  }
}, { immediate: true })

watch(() => props.result, () => {
  if (!hidden.value) {
    nextTick(() => reposition())
  }
})

// Watch for persistent state changes and result changes
watch(() => [props.isPersistent, props.result], ([isPersistent, result]) => {
  if (!isPersistent && !result) {
    // Hide tooltip when both persistent mode is off and no result
    hidden.value = true
  } else if (result && (isPersistent || props.event?.type === 'mouseenter')) {
    // Show tooltip when there's a result and either persistent or hovering
    hidden.value = false
    nextTick(() => reposition())
  }
})

// Watch for route changes and hide tooltip
watch(() => route.path, () => {
  hidden.value = true
  targetElement.value = null
})
</script>