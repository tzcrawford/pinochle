<!--
    HeaderUserBanner: Details quick information about the user if they are logged in. 
    Or offers them a link to log in.
-->
<script lang="ts">
    import { username } from './store.js'
    let userSkillLevel
    let userGamesPlayed
    let userWLRat
    let userLocation
    let userLanguage
</script>

<div class="BannerBlock">
    {#if $username === null }
        Not logged in
    {:else}
        <br />
        <table class="userBannerContent">
            <tr>
                <td>
                    User:
                </td><td>
                    <strong>{$username}</strong>
                </td><td>
                    Skill Level:
                </td><td>
                    <strong>{userSkillLevel}</strong>
                </td>
            </tr><tr>
                <td>
                    Games Played:
                </td><td>
                    <strong>{userGamesPlayed}</strong>
                </td><td>
                    W/L Ratio:
                </td><td>
                    <strong>{userWLRat}</strong>
                </td>
            </tr><tr>
                <td>
                    Location:
                </td><td>
                    <strong>{userLocation}</strong>
                </td><td>
                    Language:
                </td><td>
                    <strong>{userLanguage}</strong>
                </td>
            </tr>
        </table>
    {/if}
</div>

<style>
    .BannerBlock {
        display: flex;
        flex-direction: column;
        justify-content: center;
        height: 100%;
        max-width: 600px;
        background-color: #aaaaaa;
        text-align: center;
        padding: 0px 20px;
        margin: auto;
    }
    table.userBannerContent {
        text-align: right;
    }
    td {
        padding: 0 10px;
    }
</style>

