<script lang="ts">
    import { config } from './store.js'
    export let enabled = false

    function handleMouseHover() {
        // For handling how the card is highlighted during mouse hover
        console.log(highlightable)
        highlightColor = $config.cardStyle.highlightColor
    }
</script>

{#if enabled}
    <div class="highlight-box" style="z-index: 100" >
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
    background-color: highlightColor;
}
</style>
