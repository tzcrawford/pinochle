<!--
Header : What the top of the page will show
    * Site title (Can change in config)
        * Links to root web page (Can change link in config)
            * Should this post back?
-->

<script lang="ts">
    export let siteTitle = "Pinochle Site"
    export let titleHREF = "localhost:5000"
    export let topBarBackColor = "#cccccc"
    export let titleTextSize = "3em"
    export let titleTextColor = "#ff3e00"
    export let titleTextHoverColor = "#ff3e00"
    let titleTextColor_ = titleTextColor // We have this just to have something re-assignable on hover
    let setTitleTextColorHover = (isHovered) => {
        titleTextColor_ = isHovered ? titleTextHoverColor : titleTextColor;
    }
    export let titleBold = "true"
    export let titleTextAdditionalStyle = ""
</script>

<header class="TopBar"
    style={"background-color: " + topBarBackColor + ";font-weight: normal;"}
>
    <div class="LineContainer">
        <div class="WebTitle"
        >
        <a href={titleHREF}
            style={`color: ${titleTextColor_}; font-size: ${titleTextSize}; ${titleTextAdditionalStyle}`}
            on:mouseenter={() => setTitleTextColorHover(true)}
            on:mouseleave={() => setTitleTextColorHover(false)}
        >
            {#if titleBold == "true"} <!-- Do NOT remove quotes around true LOL -->
                <span style="font-weight: bold">{siteTitle}</span>
            {:else}
                <span style="font-weight: normal">{siteTitle}</span>
            {/if}
        </a>
        </div>
        <div class="UserInfo">
            <slot></slot>
        </div>
    </div>
</header>

<style>
    /* Manually setting some styles like global h1 */
    .TopBar {
        text-align: left;
        overflow: hidden;
        margin: none;
    }
    .LineContainer {
        display: flex;
        justify-content: space-between;
    }
    .WebTitle {
        text-align: left;
    }
    .WebTitle a { 
        display: inline-block;
        text-align: left;
        text-decoration: none;
        padding: 14px 16px;
    }
</style>
