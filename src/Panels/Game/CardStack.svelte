<!--
CardStack: Renders a stack of cards, like in a hand or group of melt
    * Must handle rotation of this object in surrounding objects.
    * Must highlight individual cards if it can be selected.
-->

<script lang="ts">
    import Card from './Card.svelte'
    export let additionalStyle="max-width:7em;width:7em;" // Needs to match width of card

    // Default overlap distance of the cards, should compare to the default width (currently 7)
    /* 0 would be the cards touching end-to-end, we set negative to shift left */
    export let overlap = "-4em";

    export let cards = ["cA", "dJ"]//, "sQ", "w8"]
    export let highlightable = {"cA": false, "dJ": true}//, "sQ":true}
    /**
    NOTE For the cards definition, we use:
    c for clubs, d for diamonds, s for spades, and h for hearts
    The reason for this is difficulty comparing equality of unicode characters, especially in JS
    The suit unicode-16 character requires two 16-bit units rather than the typical one 16-bit unit. 
    ***/
</script>

<div class="horizontal-stack" style="z-index: 0;" >
    {#each cards as card, i}
        {#if card.length === 2}
            <div class="card-item" 
                style="{additionalStyle}; z-index: {1+2*i}; margin-right: {overlap};" >
                <!-- We use 1+2*i for z-index because: 1 for background, 2*i for card height in stack, multiplication by two to leave space for highlight layers. -->
                {#if card in highlightable && highlightable[card] === true }
                    <Card suit={card[0]} rank={card[1]} highlightable={highlightable[card]} 
                          highlightPositionStyle="z-index: {1+2*i+1}; margin-right: {overlap}; margin-top:-1em; {additionalStyle};"
                          cardAdditionalStyle=""
                    />
                    <!-- We use 1+2*i+1 for z-index because: 1 for background, 2*i for card, another 1 to sit above card-->
                {:else}
                    <Card suit={card[0]} rank={card[1]} />
                {/if}
            </div>
        {:else}
            <div class="card-item" 
                style="{additionalStyle}; z-index: {1+i}; margin-right: {overlap};" >
                <Card suit="j" rank="7" />
            </div>
        {/if}
    {/each}
</div>


<style>
.horizontal-stack {
    display: flex;
    justify-content: space-between;
    width: 0em;
}
.card-item {
    /* margin-right: overlap; Svelte does not support setting this dynamically, it must be declared on the object style at runtime.*/
    margin-top: 0;
    margin-bottom: 0;
    padding: 0;
    margin-left: 0;
    position: relative; /* This is needed to make z-index of subsequent cards apply */
    
    /* This may help with opaqueness, but may also affect rounded corners. */
    /*background-color: rgba(255, 255, 255, 1); */ 
}
/* Remove the margin from the last card to prevent extra spacing (Applies automatically)*/
.card-item:last-child {
    margin-right: 0;
    /*background-color: rgba(255, 255, 255, 1) */
    position:relative;
}
</style>
