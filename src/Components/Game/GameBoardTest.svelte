<!--
GameBoard : Holds all game elements once entering the game
-->

<script lang="ts">
import CardStack from './CardStack.svelte'
</script>
<div class="game-board-cont0">
    <div class="game-board-cont1">
        <div class="left-player0">
            <div class="left-player1">
                <CardStack />
            </div>
        </div>
        <div class="top-player0">
            <CardStack />
        </div>
        <div class="bottom-player0">
            <CardStack />
        </div>
        <div class="right-player0">
            <div class="right-player1">
                <CardStack />
            </div>
        </div>
    </div>
</div>

<style>
div.game-board-cont0 {
    height: 100vh;
    width: 100vw;
    overflow: hidden;
}
div.game-board-cont1 {
    display: grid;
    grid-gap: 0px;
    grid-template-columns: [col1-start] 20% [col2-start] 60% [col3-start] 20% [col3-end];
    grid-template-rows: [row1-start] auto [row2-start] auto [row2-end];
    width: 100%;
    height: 90%;
}
div.top-player0 {
    grid-column: col2-start/col3-start;
    grid-row: row1-start/row2-start;
    align-self: start;
    justify-self: center;
}
div.bottom-player0 {
    grid-column: col2-start/col3-start;
    grid-row: row2-start/row2-end;
    align-self: end;
    justify-self: center;
}

div.left-player0 {
    grid-column: col1-start/col2-start;
    grid-row: row1-start/row2-end ;
    align-self: center;
    justify-self: center;
}
div.right-player0 {
    grid-column: col3-start/col3-end;
    grid-row: row1-start/row2-end ;
    align-self: center;
    justify-self: center;
}
div.left-player1 {
    transform: rotate(90deg);
}
div.right-player1 {
    transform: rotate(-90deg);
}
</style>
