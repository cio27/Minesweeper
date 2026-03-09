import de.bezier.guido.*;

private static final int NUM_ROWS = 20;
private static final int NUM_COLS = 20;
private static final int NUM_MINES = 40;

private MSButton[][] buttons;
private ArrayList<MSButton> mines;

void setup()
{
    size(400, 400);
    textAlign(CENTER, CENTER);
    Interactive.make(this);

    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    for (int r = 0; r < NUM_ROWS; r++)
        for (int c = 0; c < NUM_COLS; c++)
            buttons[r][c] = new MSButton(r, c);

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
    for (MSButton mine : mines)
        mine.reveal();

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
            if (dr == 0 && dc == 0) continue;
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
        Interactive.add(this);
    }

    public void mousePressed()
    {
        clicked = true;

        if (mouseButton == RIGHT)
        {
            flagged = !flagged;
            if (!flagged)
                clicked = false;
        }
        else if (mines.contains(this))
        {
            displayLosingMessage();
        }
        else
        {
            int neighboring = countMines(myRow, myCol);
            if (neighboring > 0)
            {
                setLabel(neighboring);
            }
            else
            {
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
            fill(0);
        else if (clicked && mines.contains(this))
            fill(255, 0, 0);
        else if (clicked)
            fill(200);
        else
            fill(100);

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

    public void reveal()
    {
        clicked = true;
        flagged = false;
    }
}
