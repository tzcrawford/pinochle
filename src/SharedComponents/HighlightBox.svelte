<script lang="ts">
    import { config } from './store.js'
    export let enabled = false
    export let highlightPositionStyle = "z-index: 0"
    let highlightColor = "rgba(0,0,0,0)"
    highlightColor = $config.cardStyle.highlightColor

    function handleMouseHover() {
        // For handling how the card is highlighted during mouse hover
        console.log(highlightable)
        highlightColor = $config.cardStyle.highlightColor
    }
</script>

{#if enabled}
    <div class="highlight-box" 
        style="background-color: {highlightColor};{highlightPositionStyle}">
        <!-- We use a high z-index to make sure this goes on top of the CardStack -->
        <slot />
    </div>
{:else}
    <slot />
{/if}

<style>
.highlight-box {
    /* The user should get a pointer mouse symbol only when the card is playble (highlightable) */
    cursor: pointer;
    position:relative;
}
</style>
