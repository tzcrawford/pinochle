<!--
Card :
    * Rank and suit, must include unicode symbol
-->

<script lang="ts">
    import { config } from '../SharedComponents/store.js'
    let backgroundColor = $config.cardStyle.backColor

    import HighlightBox from '../SharedComponents/HighlightBox.svelte'
    import DropShadowTile from '../SharedComponents/DropShadowTile.svelte'
    export let cardAdditionalStyle = ""
    export let suit
    export let rank
    export let cardText
    export let highlightable = false
    let highlightBoxEnabled = false
    export let highlightPositionStyle = ""
    export let cardHighlightedStyle = ""
    if(!cardText) {
        cardText=suit+rank
    } else {
        if(cardText.length === 2 && ((!suit) || (!rank)))
        suit = cardText[0]
        rank = cardText[1]
    }

    let cardColor="green"
    if(suit == "s") {
        cardColor = "black"
        cardText = "♠️" + rank
    } else if(suit == "c") {
        cardColor = "black"
        cardText = "♣️" + rank
    } else if(suit == "d") {
        cardColor = "red"
        cardText = "♦️" + rank
    } else if(suit == "h") {
        cardColor = "red"
        cardText = "♥️" + rank
    } else {
        cardText="UNK"
        cardColor="blue"
    }

    function handleMouseOver() {
        //console.log("running mouseover for:", cardText)
        if(highlightable) {
            //console.log("enabling HighlightBox for:", cardText)
            highlightBoxEnabled = true
            cardHighlightedStyle="margin-top:-1em;"
        }
    }
    function handleMouseOut() {
        highlightBoxEnabled = false
        cardHighlightedStyle=""
    }

</script>

<div class="card"
    on:mouseover={handleMouseOver}
    on:mouseout={handleMouseOut}
    on:focus={() => {}}
    on:blur={() => {}}
> <!-- A container for the whole card -->
    <DropShadowTile 
        additionalStyle="max-width:7em;width:7em;max-height:12em;height:12em;margin:0;padding:0px;background-color: {backgroundColor};{cardHighlightedStyle};{cardAdditionalStyle}"
    >
            <HighlightBox enabled={highlightBoxEnabled} highlightPositionStyle={highlightPositionStyle}>
            <div class="top-char-cont">
                <div class="top-char-text" style="color: {cardColor}" >
                    {cardText}
                </div>
            </div>
            <div class="bottom-char-cont">
                <div class="bottom-char-text" style="color: {cardColor}" >
                    {cardText}
                </div>
            </div>
        </HighlightBox>
    </DropShadowTile>
</div>

<style>
.top-char-cont {
    text-align:left;
    margin: 0;
    padding: 0.333em;
    max-height: 5.333em;
    min-height: 5.333em;
    position: relative;
    top: 0;
    left: 0;
    overflow:hidden;
    /*border: 0.3px solid #f00;*/
}
.bottom-char-cont {
    text-align: left;
    margin: 0;
    padding: 0.333em;
    max-height: 5.333em;
    min-height: 5.333em;
    position: relative;
    overflow:hidden;
    /*border: 0.3px solid #0f0;*/
}
.top-char-text {
    position: absolute;
    top: 0;
    left: 0;
    transform: rotate(0deg);
    /*border: 0.3px solid #a00;*/
    font-size: 120%;
    padding: 0.1em;
    margin: 0;
}
.bottom-char-text {
    position: absolute;
    bottom: 0;
    right: 0;
    transform: rotate(180deg);
    /*border: 0.3px solid #0a0;*/
    font-size: 120%;
    padding: 0.1em;
    margin: 0;
}
</style>
