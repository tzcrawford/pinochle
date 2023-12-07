<!--
App : The main component that handles the overall structure of your app. 
    * Manages routing between menus
-->

<script lang="ts">
    import { writable } from 'svelte/store'
    import Header from './SharedComponents/Header.svelte'
    import Footer from './SharedComponents/Footer.svelte'
    import { authToken } from './SharedComponents/store.js'
    import Authentication from './Panels/Authentication/Authentication.svelte'
    import { fade, blur, fly, slide, scale, draw, crossfade } from 'svelte/transition'
    
    /*** Get random number in header ***/
    function getRand() {
        fetch("./rand")
        .then(d => d.text())
        .then(d => (rand = d));
    }
    let rand = getRand();
    
</script>

<main>
    <Header />
    <h2>Your number is {rand}!</h2>
    <button on:click={getRand}>Get a random number</button>
    <br /><br /><br /><br />
    {#if $authToken === null}
        <Authentication />
    {/if}
    <Footer />
</main>

<style>
</style>
