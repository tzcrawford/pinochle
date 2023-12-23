<!--
CardStack: Renders a stack of cards, like in a hand or group of melt
-->

<script lang="ts">
    import Card from './Card.svelte'
    let additionalStyle="max-width:7em;width:7em;" // Needs to match width of card

    // Default overlap distance of the cards, should compare to the default width (currently 7)
    /* 0 would be the cards touching end-to-end, we set negative to shift left */
    export let overlap = "-4em";

    let testStack = [0, 1, 2]
</script>

<div class="horizontal-stack" style="z-index: 0" >
    {#each testStack as i}
        <div class="item" 
             style="{additionalStyle}; z-index: ${1+i}em; margin-right: {overlap};" >
            <Card />
        </div>
    {/each}
</div>


<style>
.horizontal-stack {
    display: flex;
    justify-content: space-between;
    width: 0em;
}
.item {
    /* margin-right: overlap; Svelte does not support setting this dynamically, it must be declared on the object style at runtime.*/
    margin-top: 0;
    margin-bottom: 0;
    padding: 0;
    margin-left: 0;
    position: relative; /* This is needed to make z-index of subsequent cards apply */
    
    /* This may help with opaqueness, but may also affect rounded corners. */
    /*background-color: rgba(255, 255, 255, 1); */ 
}
/* Remove the margin from the last item to prevent extra spacing (Applies automatically)*/
.item:last-child {
    margin-right: 0;
    /*background-color: rgba(255, 255, 255, 1) */
}
</style>
