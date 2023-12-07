<!--
Header : What the top of the page will show
    * Site title (Can change in config)
        * Links to root web page (Can change link in config)
            * Should this post back?
-->

<script lang="ts">
</script>

<header class="TopBar">
    <a href="localhost:5000" >
        Pinochle Site
    </a>
</header>

<style>
    /* Manually setting some styles like global h1 */
    .TopBar {
        text-align: left;
        font-size: 3em;
        background-color: #cccccc;
        overflow: hidden;
        margin: none;
    }
    .TopBar a { 
        display: inline-block;
        text-align: left;
        font-weight: bold;
        color: #ff3e00;
        padding: 14px 16px;
        text-decoration: none;
    }
    .TopBar a:hover {
      color: #ef2e00;
    }
</style>
