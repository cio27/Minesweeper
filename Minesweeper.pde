import de.bezier.guido.*;

// Constants
private static final int NUM_ROWS = 20;
private static final int NUM_COLS = 20;
private static final int NUM_MINES = 40;

private MSButton[][] buttons; // 2d array of minesweeper buttons
private ArrayList<MSButton> mines; // ArrayList of just the minesweeper buttons that are mined

void setup()
{
    size(400, 400);
    textAlign(CENTER, CENTER);

    // make the manager
    Interactive.make(this);

    // Initialize the 2D array
    buttons = new MSButton[NUM_ROWS][NUM_COLS];

    // Create a new MSButton for each row/column pair
    for (int r = 0; r < NUM_ROWS; r++)
        for (int c = 0; c < NUM_COLS; c++)
            buttons[r][c] = new MSButton(r, c);

    // Initialize mines list
    mines = new ArrayList<MSButton>();

    setMines();
}

public void setMines()
{
    while (mines.size() < NUM_MINES)
    {
        int row = (int)(Math.random() * NUM_ROWS);
        int col = (int)(Math.random() * NUM_COLS);
        if (!mines.contains(buttons[row][col]))
            mines.add(buttons[row][col]);
    }
}

public void draw()
{
    background(0);
    if (isWon())
        displayWinningMessage();
}

public boolean isWon()
{
    // Win if every non-mine button has been clicked AND every mine is flagged
    for (int r = 0; r < NUM_ROWS; r++)
    {
        for (int c = 0; c < NUM_COLS; c++)
        {
            MSButton b = buttons[r][c];
            if (mines.contains(b))
            {
                if (!b.isFlagged()) return false;
            }
            else
            {
                if (!b.isClicked()) return false;
            }
        }
    }
    return true;
}

public void displayLosingMessage()
{
    // Reveal all mines
    for (MSButton mine : mines)
        mine.setLabel("X");

    // Write LOSE across the middle row
    String msg = "YOU LOSE!";
    int midRow = NUM_ROWS / 2;
    for (int c = 0; c < msg.length() && c < NUM_COLS; c++)
        buttons[midRow][c + (NUM_COLS - msg.length()) / 2].setLabel("" + msg.charAt(c));
}

public void displayWinningMessage()
{
    String msg = "YOU WIN!";
    int midRow = NUM_ROWS / 2;
    for (int c = 0; c < msg.length() && c < NUM_COLS; c++)
        buttons[midRow][c + (NUM_COLS - msg.length()) / 2].setLabel("" + msg.charAt(c));
}

public boolean isValid(int r, int c)
{
    return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

public int countMines(int row, int col)
{
    int numMines = 0;
    for (int dr = -1; dr <= 1; dr++)
    {
        for (int dc = -1; dc <= 1; dc++)
        {
            if (dr == 0 && dc == 0) continue; // skip self
            int nr = row + dr;
            int nc = col + dc;
            if (isValid(nr, nc) && mines.contains(buttons[nr][nc]))
                numMines++;
        }
    }
    return numMines;
}

public class MSButton
{
    private int myRow, myCol;
    private float x, y, width, height;
    private boolean clicked, flagged;
    private String myLabel;

    public MSButton(int row, int col)
    {
        width  = 400 / NUM_COLS;
        height = 400 / NUM_ROWS;
        myRow  = row;
        myCol  = col;
        x      = myCol * width;
        y      = myRow * height;
        myLabel = "";
        flagged = clicked = false;
        Interactive.add(this); // register it with the manager
    }

    // called by manager
    public void mousePressed()
    {
        clicked = true;

        if (mouseButton == RIGHT)
        {
            // Toggle flag
            flagged = !flagged;
            if (!flagged)
                clicked = false; // un-click when unflagging
        }
        else if (mines.contains(this))
        {
            // Hit a mine — game over
            displayLosingMessage();
        }
        else
        {
            int neighboring = countMines(myRow, myCol);
            if (neighboring > 0)
            {
                setLabel(neighboring); // show number
            }
            else
            {
                // Recursively reveal all 8 neighbors
                for (int dr = -1; dr <= 1; dr++)
                {
                    for (int dc = -1; dc <= 1; dc++)
                    {
                        if (dr == 0 && dc == 0) continue;
                        int nr = myRow + dr;
                        int nc = myCol + dc;
                        if (isValid(nr, nc) && !buttons[nr][nc].isClicked())
                            buttons[nr][nc].mousePressed();
                    }
                }
            }
        }
    }

    public void draw()
    {
        if (flagged)
            fill(255, 200, 0);        // yellow = flagged
        else if (clicked && mines.contains(this))
            fill(255, 0, 0);          // red = mine revealed
        else if (clicked)
            fill(200);                // light grey = clicked
        else
            fill(100);                // dark grey = unclicked

        rect(x, y, width, height);
        fill(0);
        text(myLabel, x + width / 2, y + height / 2);
    }

    public void setLabel(String newLabel)
    {
        myLabel = newLabel;
    }

    public void setLabel(int newLabel)
    {
        myLabel = "" + newLabel;
    }

    public boolean isFlagged()
    {
        return flagged;
    }

    public boolean isClicked()
    {
        return clicked;
    }
}
