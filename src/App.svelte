<!--
App : The main component that handles the overall structure of your app. 
    * Manages routing between menus
-->

<script lang="ts">
    import { writable } from 'svelte/store'
    //import { fade, blur, fly, slide, scale, draw, crossfade } from 'svelte/transition'

    //import PopUpWindow from './SharedComponents/PopUpWindow.svelte'

    import Header from './SharedComponents/Header.svelte'
    import Footer from './SharedComponents/Footer.svelte'
    
    import Authentication from './Panels/Authentication/Authentication.svelte'
    
    /*** Get random number in header ***/
    function getRand() {
        fetch("./rand")
        .then(d => d.text())
        .then(d => (rand = d));
    }
    let rand = getRand();
    
</script>

<main>
    <Header 
        siteTitle="alternate title"
        titleHREF="https://google.com"
        topBarBackColor="red"
        titleTextSize="1em"
        titleTextColor="pink"
        titleTextHoverColor="green"
        titleBold=false
        titleTextAdditionalStyle="padding: 80px"
    >
        test test
        <br />
        test test test
    </Header>
    <Authentication />
    <h2>Your number is {rand}!</h2>
    <button on:click={getRand}>Get a random number</button>
    <br /><br /><br /><br />
    <Footer />
</main>

<style>
</style>
