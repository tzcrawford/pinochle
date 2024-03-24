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
        <div class="left-player-melt0">
            <div class="left-player-melt1">
                <div class="left-player-melt2">
                    <CardStack />
                </div>
            </div>
        </div>
        <div class="top-player0">
            <CardStack />
        </div>
        <div class="top-player-melt0">
            <div class="top-player-melt1">
                <CardStack />
            </div>
        </div>
        <div class="tricks0">
            <div class="tricks1">
                <CardStack />
            </div>
        </div>
        <div class="bottom-player-melt0">
            <div class="bottom-player-melt1">
                <CardStack />
            </div>
        </div>
        <div class="bottom-player0">
            <CardStack />
        </div>
        <div class="right-player-melt0">
            <div class="right-player-melt1">
                <div class="right-player-melt2">
                    <CardStack />
                </div>
            </div>
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
    grid-template-columns: [col1-start] 20% [col2-start] 10% [col3-start] 40% [col4-start] 10% [col5-start] 20% [col5-end];
    grid-template-rows: [row1-start] 20% [row2-start] 10% [row3-start] 40% [row4-start] 10% [row5-start] 20% [row5-end];
    width: 100%;
    height: 90%;
}
div.left-player0 {
    grid-column: col1-start/col2-start;
    grid-row: row1-start/row5-end ;
    align-self: center;
    justify-self: center;
}
div.left-player-melt0 {
    grid-column: col2-start/col3-start;
    grid-row: row1-start/row5-end ;
    align-self: center;
    justify-self: center;
}
div.top-player0 {
    grid-column: col3-start/col4-start;
    grid-row: row1-start/row2-start;
    align-self: start;
    justify-self: center;
}
div.top-player-melt0 {
    grid-column: col3-start/col4-start;
    grid-row: row2-start/row3-start;
    align-self: start;
    justify-self: center;
}
div.tricks0 {
    grid-column: col3-start/col4-start;
    grid-row: row3-start/row4-start;
    align-self: center;
    justify-self: center;
}
div.bottom-player-melt0 {
    grid-column: col3-start/col4-start;
    grid-row: row4-start/row5-start;
    align-self: end;
    justify-self: center;
}
div.bottom-player0 {
    grid-column: col3-start/col4-start;
    grid-row: row5-start/row5-end;
    align-self: end;
    justify-self: center;
}
div.right-player-melt0 {
    grid-column: col4-start/col5-start;
    grid-row: row1-start/row5-end ;
    align-self: center;
    justify-self: center;
}
div.right-player0 {
    grid-column: col5-start/col5-end;
    grid-row: row1-start/row5-end ;
    align-self: center;
    justify-self: center;
}
div.left-player1 {
    transform: rotate(90deg);
}
div.right-player1 {
    transform: rotate(-90deg);
}
div.left-player1 {
    transform: rotate(90deg);
}
div.left-player-melt1 {
    transform: rotate(90deg);
}
div.left-player-melt2 {
    transform: scale(0.5);
}
div.top-player-melt1 {
    transform: scale(0.5);
}
div.bottom-player-melt1 {
    transform: scale(0.5);
}
div.right-player1 {
    transform: rotate(-90deg);
}
div.right-player-melt1 {
    transform: rotate(-90deg);
}
div.right-player-melt2 {
    transform: scale(0.5);
}
div.tricks1 {
    transform: scale(0.7);
} </style>
