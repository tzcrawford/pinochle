<script lang="ts">
  let myvar = '';

  (async () => {
    try {
      const response = await fetch('/game_state/test');
      if (!response.ok) throw new Error('Failed to fetch data');
      const data = await response.json();
      myvar = data.message;
    } catch (error) {
      console.error('Error fetching data:', error);
    }
    })();
</script>

{myvar}
