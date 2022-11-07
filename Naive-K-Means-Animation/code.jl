using DataFrames, Random, Plots

# Set work directory to the saved directory
cd(@__DIR__)

# Set seed of rng for reproduceability
Random.seed!(2001)

# Function to get the n data points in R2
function getdata(n)
    points1x = []
    points1y = []
    points2x = []
    points2y = []
    points3x = []
    points3y = []
    # Gather 3 different normally distributed clusters in R2 for the data of total size n
    for i in 1:n
        r = rand()
        if r <= 1/3
            x, y = [1.2 + sqrt(0.1)*randn(), 1.3 + sqrt(0.3)*randn()]
            push!(points1x, x)
            push!(points1y, y)
        elseif r <= 2/3
            x, y = [-0.8 + sqrt(0.1)*randn(), 0.3 + sqrt(0.3)*randn()]
            push!(points2x, x)
            push!(points2y, y)
        else
            x, y = [0.2 + sqrt(0.8)*randn(), -1.2 + sqrt(0.05)*randn()]
            push!(points3x, x)
            push!(points3y, y)
        end
    end
    data = [[points1x, points1y], [points2x, points2y], [points3x, points3y]]
end

# Function to plot the initial data with colour coded clusters
function plotdata(data)
    p = plot(xlim = [-2, 2], ylim = [-2, 2], legend = :outertopright)
    for points in data
        p = scatter!(points[1], points[2])
    end
    display(p)
end

# Function to create and display the animation of the K-Means algorithm acting on the data which is in R2
function k_means_anim(data, k, steps)
    xdata = vcat([points[1] for points in data]...)
    ydata = vcat([points[2] for points in data]...)
    n = length(xdata)
    # Initial plot
    plots = Vector{Any}(undef, steps+1)
    p = scatter(xdata, ydata, xlim = [-2, 2], ylim = [-2, 2], title = "Step 0", color = :grey, legend = :outertopright)
    # Initial means
    xmeans = 4*rand(k) .- 2
    ymeans = 4*rand(k) .- 2
    p = scatter!(xmeans, ymeans, marker = :xcross, color = :purple)
    plots[1] = p

    # Iterate over the number of corrections to the mean we want to do
    for s in 1:steps
        points = [[xdata[i], ydata[i]] for i in 1:n]
        squared_distances = zeros(n)
        point_class = zeros(n)

        # Iterate over each point and find its corresponding mean which is closest
        for i in 1:n
            point = points[i]
            d = Inf
            mean_index = 0
            for j in 1:k
                mean = [xmeans[j], ymeans[j]]
                new_d = sum((point - mean) .^ 2)
                if new_d < d
                    d = new_d
                    mean_index = j
                else
                    nothing
                end
            end
            squared_distances[i] = d
            point_class[i] = mean_index
        end

        xpoints_class = []
        xmeans = []
        ypoints_class = []
        ymeans = []
        for j in 1:k
            class = points[point_class .== j]
            xclass = map(a -> a[1], class)
            yclass = map(a -> a[2], class)
            push!(xpoints_class, xclass)
            push!(xmeans, sum(xclass)/length(xclass))
            push!(ypoints_class, yclass)
            push!(ymeans, sum(yclass)/length(yclass))
        end
        p = scatter(xpoints_class, ypoints_class, xlim = [-2, 2], ylim = [-2, 2], title = "Step $s", legend = :outertopright)
        p = scatter!(xmeans, ymeans, marker = :xcross, color = 1:k)
        plots[s+1] = p

        xdata = vcat(xpoints_class...)
        ydata = vcat(ypoints_class...)
    end

    # Creates the animation
    anim = 
    @animate for s in 1:steps+1
        plot(plots[s])
    end

    # Displays the animation
    fps = ceil(steps / 10)
    display(gif(anim, "Naive K-Means.gif", fps = fps))
    return plots
end

data = getdata(300)

plotdata(data)

plots = k_means_anim(data, 4, 10)

display(plots[end])
