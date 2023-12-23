<!--
Card :
    * Rank and suit, must include symbol
    * Highlights on hover if can be selected
    * Rotation (due to who is holding it
-->

<script lang="ts">
    import DropShadowTile from '../../SharedComponents/DropShadowTile.svelte'
    let test_char="♠️A"
</script>

<DropShadowTile 
    additionalStyle="max-width:7em;width:7em;max-height:12em;height:12em;margin:0;padding:0px">
<div class="top-char-cont">
        <div class="top-char-text">
            {test_char}
        </div>
    </div>
    <div class="bottom-char-cont">
        <div class="bottom-char-text">
            {test_char}
        </div>
    </div>
</DropShadowTile>

<style>
.top-char-cont {
    text-align:left;
    margin: 0px;
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
    margin: 0px;
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
