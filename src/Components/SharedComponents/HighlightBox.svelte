<script lang="ts">
    import { config } from './store.js'
    export let highlightPositionStyle
    let highlightColor
    
    export let enabled = false
    setDisabled() // set default behavior
    $: ( () => { // This will make handleEnabled when the reactive value enabled changes
        (enabled); // enabled may not actually used here but s present a function ran. Needed to be reactive on enabled value.
        //console.log("enabled val:",enabled)
        handleEnabled()
        } 
    ) ()

    function setDisabled() {
        highlightPositionStyle = "z-index: 0"
        highlightColor = "rgba(0,0,0,0)"
    }

    function handleEnabled() {
        // For handling how the card is highlighted
        //console.log("handleEnabled is running")
        if(enabled) {
            //console.log("setting highlightColor")
            highlightColor = $config.cardStyle.highlightColor
        } else {
            setDisabled()
        }

    }
</script>

<div class="highlight-box" 
     style="background-color: {highlightColor};{highlightPositionStyle}">
    <slot />
</div>

<style>
.highlight-box {
    position: relative;
    cursor: pointer;
}
</style>
