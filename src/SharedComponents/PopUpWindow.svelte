<!--
PopUpWindow : Pop up for warning or error
    We do not implement Y/N buttons or acknowledge button because that should be handled by the wrapping script with an element in the inner slot. 
    We could make a wrapper for this with a acknowledge or Y/N buttons, but that would prevent the inner slot elements from highjacking then entire CSS style within the popUp window (e.g. back color would not consume the whole round-edge box)
--> 
<script lang="ts">
    import { fade } from 'svelte/transition'

    export let showPopUp = false;
    export let maxWidth = "400px"
    export let additionalStyle = ""
</script>

{#if showPopUp}
    <div class="backdrop" on:click|self on:keydown={() => {}} 
        transition:fade={{ delay: 100, duration: 333 }}
    >
        <!-- the on:click|self event-->
        <!-- We add the keydown event with no effect to suppress an A11y warning -->
        <div class="popUp" style="max-width: {maxWidth}; {additionalStyle}" >
          <slot></slot>
        </div>
    </div>
{/if}

<style>
  .backdrop{
    width: 100%;
    height: 100%;
    position: fixed;
    background: rgba(0,0,0,0.8);
  }
  .popUp{
    padding: 10px;
    border-radius: 10px;
    margin: 10% auto;
    text-align: center;
  }
</style>
